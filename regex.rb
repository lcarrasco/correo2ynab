

file = File.open("ejemplo.html", "rb")
mensaje = file.read

cantidad = mensaje.match(/color:#666666;" width="298"><b>(.*)<\/b>/)
cantidad = cantidad[1].gsub(/\$/, '')
puts cantidad.to_i * 100

tarjeta = mensaje.match(/color:#666666;" width="301"><b>(.*)<\/b>/)
puts tarjeta[1]

extras = mensaje.match(/align="left" width="215"><b>(.*)<\/b><\/td>/)
puts extras[1]

fecha = mensaje.match(/height="20" width="210">(.*)<\/td><td width="20">/)
puts fecha[1]