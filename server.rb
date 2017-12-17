require 'sinatra'
require 'json'
require 'net/http'

require_relative 'fetch_transactions'
require_relative 'money_spent_on'
require_relative 'monthly_amounts'
require_relative 'transactions_by_day'


post '/dialogflow' do
	dictionary = JSON.parse request.body.string
	result = dictionary['result']
	metadata = result['metadata']
	intentName = metadata['intentName']

	params = result['parameters']

	reply = ""

	fh = open 'micb_fixture.json'
	content = fh.read
	fh.close

	parsed_hash = JSON.parse(content)
	accounts = parsed_hash['data']['accounts']

	case intentName
	when "general_balance"
		reply = "Your balance for accounts:\n"
		i = 0
		accounts.each do |account|
			i += 1
			reply += "#{i}: #{account['balance']} \n with currency: #{account['currency_code']}\n"
		end
	when "last_n_transactions"
		number_of_trans = params['number'].to_i
		reply = "Your last 5 transactions for each account are:\n"

		accounts.each do |account|
			puts i
			fetched_transactions = fetch_transactions(account['transactions'], number_of_trans)
			i = 0
			reply += "Account #{account['name']}:\n"

			fetched_transactions.each do |trans|
				i += 1
				reply += "#{i}.\nmade on: #{trans['made_on']}\n
				amount: #{trans['amount']} \n
				description: #{trans['description']}\n\n"
			end
		end
	when "month_spending"
		reply = "In average you spend every month...\n"
		accounts.each do |account|
			avg_amounts = monthly_amount(account['transactions'], -1)
			avg_amounts.each do |key, value|
				reply += "#{key} - %.2f\n" % [value]
			end
		end
	when "month_income"
		reply = "In average your monthly income is...\n"
		accounts.each do |account|
			avg_amounts = monthly_amount(account['transactions'], 1)
			avg_amounts.each do |key, value|
				reply += "#{key} - %.2f\n" % [value]
			end
		end
	when "Bitcoin"
		response = Net::HTTP.get_response("api.coindesk.com","/v1/bpi/currentprice.json")
		parsed_response = JSON.parse response.body
		bpi = parsed_response['bpi']
		puts parsed_response

		reply = "As of #{parsed_response['time']['updated']}, the Bitcoin value is...\n"
		bpi.each do |currency, info|
			reply += "#{currency} - #{info['rate']}\n"
		end
	when "transactions_by_day"
		puts params
		date = params['date-time']
		reply = "The transaction history for date #{date}:\n"
		i = 0
		accounts.each do |account|
			i += 1
			reply += "Account no. #{i}\n"
			result_array = transaction_history(account['transactions'], date)
			reply += "Money spent: %.2f\n" % result_array[0]
			puts result_array[1]
						+ "Money earned: %.2f\n" % result_array[1]
						+ "Number of transactions: #{result_array[2].length}\n"
		end
	when "spending_for_category"
		i = 0
		# puts params
		category = params['category']
		reply = "Money spent for category #{category}:\n"

		accounts.each do |account|
			i += 1
			reply += "Account no.#{i} - %.2f\n" % (-1 * money_spent_on(category, account['transactions']))
		end
	end

	response = {}
	response["speech"] = reply
	content_type :json
  	response.to_json
end
