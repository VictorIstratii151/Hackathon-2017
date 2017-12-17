
def fetch_transactions(transactions, limit)
  transaction_slice = []
  count = 0
  if limit > 20 then limit = 20 end

  limit.times do
    transaction_slice << transactions.reverse[count]
    count += 1
  end

  transaction_slice
end
