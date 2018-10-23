require 'mail'

class IncomingEmailsController < ActionController::Base

  def create
    mail = Mail.new(params[:message])
   
    body = mail.body

    # Procesamos el body
    regex_match = body.match(/color:#666666;" width="298"><b>(.*)<\/b>/)
    cantidad = ""
    cantidad = regex_match[1] if regex_match != nil
    cantidad = cantidad.gsub(/\$/, '')
	logger.info "Monto: " + cantidad
	cantidad_ynab = cantidad.to_i * 100

	tarjeta_match = body.match(/color:#666666;" width="301"><b>(.*)<\/b>/)
	cuenta = ""
	cuenta = tarjeta_match[1] if tarjeta_match != nil
	logger.info "Tarjeta: " + cuenta 

	negocio_match = body.match(/align="left" width="215"><b>(.*)<\/b><\/td>/)
	comercio = "Comercio"
	comercio = negocio_match[1] if negocio_match != nil
	logger.info "Negocio: " +  comercio

	fecha_match = body.match(/height="20" width="210">(.*)<\/td><td width="20">/)
	fecha = ""
	fecha = fecha_match[1] if fecha_match != nil 
	logger.info "Fecha: " + fecha 

	account_id = ""
	# ToDO: Asociar account_id

	if account_id != ""
		# Insertamos el registro en YNAB
		begin
			budget_id = ENV['YNAB_BUDGET_ID']
			ynab_api = YNAB::API.new(ENV['YNAB_ACCESS_TOKEN'])
		    ynab_api.transactions.create_transaction(budget_id, {
		      transaction: {
		        account_id: account_id,	        
		        date: Date.today,
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