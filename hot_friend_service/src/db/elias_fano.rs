use std::cmp::max;

/// Elias–Fano 编码的有序集合（u64），支持顺序迭代/分页/contains（线性）
#[derive(Debug, Clone)]
pub struct EliasFano {
    n: usize,          // 元素个数
    l: u8,             // 低位位宽 L
    lo32: Option<Vec<u32>>, // L ≤ 32 时使用
    lo64: Option<Vec<u64>>, // L  > 32 时使用
    hi_bits: Vec<u64>, // 一元编码的高位 bitvector（长度 = n + max_hi + 1）
    hi_len: usize,     // hi_bits 的总 bit 位数
    max_value: u64,    // 最大值（便于统计）
}

impl EliasFano {
    /// 由**严格递增**的去重数组构建；U 取 `max(x)+1`
    pub fn from_sorted(sorted: &[u64]) -> Self {
        let n = sorted.len();
        let max_value = sorted.last().copied().unwrap_or(0);
        let u = max_value.saturating_add(1);

        // L = floor(log2(U/n))，但至少 0，最多 63
        let l = if n == 0 || u <= 1 { 0 }
        else {
            let ratio = u / (n as u64);
            (63 - ratio.leading_zeros()) as u8 // ~= floor(log2(ratio))
        }.min(63);

        let lo_mask: u64 = if l == 64 { u64::MAX } else { (1u64 << l) - 1 };
        let mut max_hi: u64 = 0;

        // 低位存储
        let mut lo32: Option<Vec<u32>> = None;
        let mut lo64: Option<Vec<u64>> = None;
        if l <= 32 {
            let mut v = Vec::with_capacity(n);
            for &x in sorted {
                v.push((x & lo_mask) as u32);
                max_hi = max(max_hi, x >> l);
            }
            lo32 = Some(v);
        } else {
            let mut v = Vec::with_capacity(n);
            for &x in sorted {
                v.push(x & lo_mask);
                max_hi = max(max_hi, x >> l);
            }
            lo64 = Some(v);
        }

        // 高位一元编码：在长度 n + max_hi + 1 的位向量上，
        // 将第 i 个元素的 1 放在位置 (hi_i + i)，其中 hi_i = x_i >> L。
        let hi_len = (n as u64 + max_hi + 1) as usize;
        let mut hi_bits = vec![0u64; (hi_len + 63) / 64];

        // 逐元素置位
        for (i, &x) in sorted.iter().enumerate() {
            let hi = (x >> l) as usize;
            let pos = hi + i; // 0-based
            let word = pos >> 6;
            let bit = pos & 63;
            hi_bits[word] |= 1u64 << bit;
        }

        Self { n, l, lo32, lo64, hi_bits, hi_len, max_value }
    }

    #[inline]
    pub fn len(&self) -> usize { self.n }
    #[inline]
    pub fn is_empty(&self) -> bool { self.n == 0 }
    #[inline]
    pub fn max_value(&self) -> u64 { self.max_value }

    /// 顺序迭代器（升序），零拷贝
    pub fn iter(&self) -> EliasFanoIter<'_> {
        EliasFanoIter {
            ef: self,
            idx: 0,
            ones_seen: 0usize,
            word_idx: 0,
            word: if !self.hi_bits.is_empty() { self.hi_bits[0] } else { 0 },
            bit_base: 0usize,
        }
    }

    /// 简易包含判断（线性：顺序找前驱）
    pub fn contains(&self, target: u64) -> bool {
        let mut it = self.iter();
        while let Some(v) = it.next() {
            if v == target { return true; }
            if v > target { return false; }
        }
        false
    }

    /// 导出为 Vec（调试/合并时用）
    pub fn to_vec(&self) -> Vec<u64> {
        self.iter().collect()
    }
}

pub struct EliasFanoIter<'a> {
    ef: &'a EliasFano,
    idx: usize,        // 当前要读取的第 idx 个（0..n）
    ones_seen: usize,  // 已经遇到的 1 的数量（== idx）
    word_idx: usize,   // 当前扫描的 hi_bits word 下标
    word: u64,         // 当前 word 值（剩余未消费 bits）
    bit_base: usize,   // 当前 word 的全局 bit 起点（word_idx * 64）
}

impl<'a> Iterator for EliasFanoIter<'a> {
    type Item = u64;
    fn next(&mut self) -> Option<Self::Item> {
        if self.idx >= self.ef.n { return None; }

        // 找到下一个 1 的全局位置 pos
        let mut pos_global: usize;
        loop {
            if self.word != 0 {
                let tz = self.word.trailing_zeros() as usize;
                pos_global = self.bit_base + tz;
                // 清掉最低位的 1
                self.word &= self.word - 1;
                break;
            } else {
                // 跳到下一个 word
                self.word_idx += 1;
                if self.word_idx >= self.ef.hi_bits.len() {
                    // 理论上不会发生：n>0 时一定有足够的 1
                    return None;
                }
                self.word = self.ef.hi_bits[self.word_idx];
                self.bit_base = self.word_idx * 64;
            }
        }

        let hi = pos_global - self.ones_seen; // hi_i = pos - i
        self.ones_seen += 1;

        // 取低位
        let lo = if self.ef.l <= 32 {
            self.ef.lo32.as_ref().unwrap()[self.idx] as u64
        } else {
            self.ef.lo64.as_ref().unwrap()[self.idx]
        };
        self.idx += 1;

        let val = ((hi as u64) << self.ef.l) | lo;
        Some(val)
    }
}
