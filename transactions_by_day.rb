
def transaction_history(transactions, date)
  money_spent = 0
  money_earned = 0
  matching_transactions = []

  transactions.each do |transaction|
    if transaction['made_on'] == date
      matching_transactions << transaction
      transaction['amount'] >= 0 ? money_earned += transaction['amount'] : money_spent += transaction['amount']
    end
  end

  [money_spent, money_earned, matching_transactions]
end
