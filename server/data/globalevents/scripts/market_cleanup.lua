local RETAIN_DAYS = 30

function onThink(interval, lastExecution)
  local cutoff = os.time() - (RETAIN_DAYS * 86400)

  q(("DELETE FROM market_listings WHERE status='sold' AND sold_at IS NOT NULL AND sold_at < %d"):format(cutoff))

  q(("DELETE FROM market_listings WHERE status='cancelled' AND created_at < %d"):format(cutoff))

  q(("DELETE FROM market_payouts WHERE collected=1 AND collected_at IS NOT NULL AND collected_at < %d"):format(cutoff))

  return true
end
