require 'ynab'

# ENV['YNAB_BUDGET_ID']
budget_id = '0e3a1c10-d4b2-43e5-9629-f104459c86a7'

access_token = '9fd5bb35d682d87910e8a68398b7d0611867841d37245acb12c393ece26157b8' # ENV['']
ynab_api = YNAB::API.new(access_token)

budget_id = budget_id

#budget = ynab_api.budgets.get_budget_by_id(budget_id)

#categorias = ynab_api.categories.get_categories(budget_id)
#categorias.each do |category|
#	puts "      Name: #{category.name}"
#    puts "  Budgeted: #{category.budgeted}"
#    puts "   Balance: #{category.balance}"
#end

#exit

account_id = '13979091-c78d-471e-997a-49715407907b' # Citi Premier
category_id = 'a191ac84-de09-not-real-6c5ed8cfdabe'

  begin
    ynab_api.transactions.create_transaction(budget_id, {
      transaction: {
        account_id: account_id,
        #category_id: "73785362-7e91-4325-acef-948b15e4fa6c",
        date: Date.today,
        payee_name: 'A Test Payee',
        memo: 'I was created through the API',
        cleared: 'Cleared',
        approved: true,
        flag_color: 'Blue',
        amount: 20000
      }
    })
  rescue => e
    puts "ERROR: id=#{e.id}; name=#{e.name}; detail: #{e.detail}"
  end

#budget_response = ynab_api.budgets.get_budgets
#budgets = budget_response.data.budgets

#budgets.each do |budget|
#  puts "Budget Name: #{budget.name}"
#end