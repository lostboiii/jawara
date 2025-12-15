-- Migration: Add metode_pembayaran_id to tagih_iuran table
-- Description: Menambahkan kolom untuk menyimpan metode pembayaran yang digunakan saat bayar iuran

-- Add metode_pembayaran_id column
ALTER TABLE tagih_iuran 
ADD COLUMN IF NOT EXISTS metode_pembayaran_id UUID 
REFERENCES metode_pembayaran(id) ON DELETE SET NULL;

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_tagih_iuran_metode_pembayaran 
ON tagih_iuran(metode_pembayaran_id);

-- Add comment to document the column
COMMENT ON COLUMN tagih_iuran.metode_pembayaran_id 
IS 'Foreign key to metode_pembayaran table - payment method used for this bill';

-- Optional: Update existing records (if needed)
-- UPDATE tagih_iuran SET metode_pembayaran_id = NULL WHERE metode_pembayaran_id IS NULL;
