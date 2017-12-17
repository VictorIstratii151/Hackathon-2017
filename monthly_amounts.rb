
require 'date'

def monthly_amount(transactions, type) # 1 for incomes and -1 for spendings
  avg_amounts = {}
  month_hash = {}
  amount_and_count = Struct.new(:amount, :count)
  transaction_array = transactions

  transaction_array.each do |transaction|
    month = Date.parse(transaction["made_on"]).month

    if month_hash[month] == nil
      month_hash[month] = amount_and_count.new(0, 0)
    end
    if transaction['amount'] * type > 0
      month_hash[month].amount += transaction['amount']
      month_hash[month].count += 1
    end
  end

  month_hash.each do |key, value|
    avg_amounts[Date::MONTHNAMES[key]] = value.amount != 0 ? value.amount / value.count : 0
  end

  avg_amounts
end
