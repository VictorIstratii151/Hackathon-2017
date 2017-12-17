
def money_spent_on(category, transactions)
  resulting_transactions = []
  money_spent = 0
  test = {}

  transactions.each do |transaction|
    test[transaction['extra']['original_category']] = 0
    if transaction['extra']['original_category'] == category && transaction['amount'] < 0
      money_spent += transaction['amount']
    end
  end

  puts test

  money_spent
end
