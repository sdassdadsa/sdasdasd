/*
  # Create votes table for voting system

  1. New Tables
    - `votes`
      - `id` (uuid, primary key)
      - `candidate_name` (text, not null)
      - `user_id` (uuid, foreign key to voters)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on `votes` table
    - Add policy for public to insert votes
    - Add policy for public to read votes
    - Add unique constraint to prevent double voting

  3. Changes
    - Create votes table with proper relationships
    - Add indexes for performance
    - Set up RLS policies for security
*/

CREATE TABLE IF NOT EXISTS votes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  candidate_name text NOT NULL,
  user_id uuid NOT NULL REFERENCES voters(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now()
);

-- Add unique constraint to prevent double voting
ALTER TABLE votes ADD CONSTRAINT unique_user_vote UNIQUE (user_id);

-- Add index for better performance
CREATE INDEX IF NOT EXISTS idx_votes_candidate_name ON votes (candidate_name);
CREATE INDEX IF NOT EXISTS idx_votes_user_id ON votes (user_id);

-- Enable RLS
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;

-- Policies for votes table
CREATE POLICY "Anyone can insert votes"
  ON votes
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Anyone can read votes"
  ON votes
  FOR SELECT
  TO public
  USING (true);

-- Update voters table policies to be more permissive for this use case
DROP POLICY IF EXISTS "Users can update own voted_for" ON voters;
CREATE POLICY "Anyone can update voters"
  ON voters
  FOR UPDATE
  TO public
  USING (true)
  WITH CHECK (true);