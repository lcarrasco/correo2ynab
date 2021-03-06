require 'mail'
require 'chronic'

class IncomingEmailsController < ActionController::Base

  def create
    Rails.logger.info params
    body =  params[:html]

    # Procesamos el body
    regex_match = body.match(/width="298"><b>(.*)<\/b>/)
    cantidad = ""
    cantidad = regex_match[1] if regex_match != nil
    cantidad = cantidad.gsub(/\$/, '')
    cantidad = cantidad.gsub(/,/, '')
	logger.info "Monto: " + cantidad
	
	# Multiplicamos la cantidad por 1000 ya que es el formato que YNAB acepta, negativo
	# para que sea un outflow
	cantidad_ynab = (cantidad.to_f * -1000).to_i 

	tarjeta_match = body.match(/width="301"><b>(.*)<\/b>/)
	cuenta = ""
	cuenta = tarjeta_match[1].strip if tarjeta_match != nil
	logger.info "Tarjeta: " + cuenta 

	negocio_match = body.match(/width="215"><b>(.*)<\/b><\/td>/)
	comercio = "Comercio"
	comercio = negocio_match[1] if negocio_match != nil
	logger.info "Negocio: " +  comercio

	fecha_match = body.match(/width="210">(.*)<\/td><td width="20">/)
	fecha = ""
	fecha = fecha_match[1] if fecha_match != nil 
	logger.info "Fecha: " + fecha 

	account_id = ""
	
	ynab_api = YNAB::API.new(ENV['YNAB_ACCESS_TOKEN'])

	# Procesamos todas las cuentas del presupuesto buscando la cuenta cuyas
	# notas sean igual que el nombre de la tarjeta que reporta el banco
	account_response = ynab_api.accounts.get_accounts(ENV['YNAB_BUDGET_ID'])
	accounts = account_response.data.accounts

	accounts.each do |account|
	  if account.note.to_s != ""
		  logger.info "Account Note: '" + account.note.to_s + "' in '#{cuenta}?', " + cuenta.index(account.note.to_s).to_s
		  if cuenta.index(account.note.to_s.strip) != nil
		  	account_id = account.id 
		  	puts "*** ACCOUNT DETECTED #{account.name} ***"
		  	break
		  end
	   end
	end

	# Reemplazamos los nombres de los meses que en español difieren
	# de los nombres en ingles ya que el Chronic gem no funciona
	# con nombres en español
	fecha = fecha.gsub(/Ene/, 'Jan')
	fecha = fecha.gsub(/Abr/, 'Apr')
	fecha = fecha.gsub(/Ago/, 'Aug')
	fecha = fecha.gsub(/Dic/, 'Dec')

	if account_id != ""
		# Insertamos el registro en YNAB
		begin		
		    ynab_api.transactions.create_transaction(ENV['YNAB_BUDGET_ID'], {
		      transaction: {
		        account_id: account_id,	        
		        date: Chronic.parse(fecha),
		        payee_name: comercio,
		        memo: '',
		        cleared: 'Cleared',
		        approved: true,	     
		        amount: cantidad_ynab
		      }
		    })
		  rescue => e
		    logger.error "ERROR: id=#{e.id}; name=#{e.name}; detail: #{e.detail}"
		  end
	else
		logger.info "No se tiene un account_id, omitiendo guardar en YNAB"
	end

    render text: "OK"
  end
end