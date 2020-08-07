class CreditsController < ApplicationController
    # Validamos parámetros antes de nuestro controlador principal
    before_action :validar_params, only: [:tmc]

  # Método que devuelve el cálculo del TMC
  def tmc
    # Obtenemos el tipo de operación dado los parámetros de UF y Días
    tipos_operaciones
    # Validamos el tramo de mes que necesitamos
    validar_fecha
    # Consultamos contra la SBIF
    consultar_tmc
    # Buscamos en la trama devuelta
    buscar_tipo_sbif
    
  end

  private

    # Método que valida que los parámetros ingresados sean correctos
    def validar_params
        @uf = params[:uf]
        @dias = params[:dias]
        @fecha = params[:fecha]
        begin
            @uf = Integer(@uf)
            @dias = Integer(@dias)
            @fecha = Time.parse(@fecha)
        rescue => exception
            # Si algún parámetro no corresponde a su tipo
            # entonces devolveremos un bad_request
            render status: :bad_request
        end
    end


    # Método que genera una consulta http a la sbif
    def consultar_tmc
        # API KEY entregada por la SBIF, debe ser ingresada como
        # Variable de entorno
        begin
            apikey = ENV["API_KEY"]
            # URL Base del servicio
            base = 'https://api.sbif.cl/api-sbifv3/recursos_api/tmc/'
            # Se concatenan la url, junto a los parámetros
            # de fecha, que solicita el usuario
            request = base+@fecha.year.to_s+'/'+@fecha.month.to_s+'?apikey='+apikey+'&formato=json'
            # Se hace un request a la API
            @response = HTTParty.get(request)
        rescue => exception
            # Si la API no responde correctamente, falta la API_KEY o tarda mucho,
            # devolveremos un estado precondition_failed
            render status: :precondition_failed
        end

    end
    
    # Metodo que nos permite obtener el tipo d
    def buscar_tipo_sbif
        begin
            # Validamos si es un json, en caso contrario caerá en rescue
            body = JSON.parse(@response.body)
            # Recorremos el arreglo, para encontrar nuestra tasa
            for i in body["TMCs"] do
                # Si es el tipo de operación que coincide, entonces
                # devolveremos la TMC
                if i["Tipo"] == @tipo.to_s
                    @valor = i["Valor"]
                    return render json: {tmc: @valor}, status: :ok
                end
            end
            # Si por algún motivo, no encontramos el tipo
            # entonces devolvemos un estado de no encontrado
            render status: :not_found
        rescue => exception
            # Si algo falla o bien el SBIF, no responde con los datos
            # devolveremos un expectation_failed
            render status: :expectation_failed
        end
    end

    # Metodo que nos devuelve el tipo de operacion, basado en los parametros
    # que el usuario entrega mediante la url, tanto de UF como Días
    def tipos_operaciones
        @tipo = nil
        # "Tipo": "22" operaciones reajustables pesos > año, UF > 2k
        if (@dias > 365 and @uf > 2000 )
            @tipo = 22
        # "Tipo": "24" operaciones reajustables pesos > año, UF <= 2k
        elsif (@dias > 365 and @uf <= 2000 )
            @tipo = 24
        # "Tipo": "25" operaciones NO reajustables pesos < 90 dias, UF > 5k
        elsif (@dias < 90 and @uf > 5000 )
            @tipo = 25
        # "Tipo": "26" operaciones NO reajustables pesos < 90 dias, UF <= 5k
        elsif (@dias < 90 and @uf <= 5000 )
            @tipo = 26
        # "Tipo": "34" operaciones NO reajustables pesos >= 90 dias, UF > 5k
        elsif (@dias >= 90 and @uf > 5000 )
            @tipo = 34
        # "Tipo": "35" operaciones NO reajustables pesos >= 90 dias, UF <= 5k & UF > 200
        elsif (@dias >= 90 and @uf <= 5000 and @uf > 200)
            @tipo = 35
        # "Tipo": "44" operaciones NO reajustables pesos >= 90 dias, UF > 50 & UF < 200
        elsif (@dias >= 90 and @uf > 50 and @uf < 200 )
            @tipo = 44
        # "Tipo": "45" operaciones NO reajustables pesos >= 90 dias, UF < 50
        elsif (@dias >= 90 and @uf < 50 )
            @tipo = 45
        else
            return render status: :not_found
        end
    end

    # Debido a que la SBIF cambia sus tazas cada 30 dias, a los dias 15
    # de cada mes, requerimos hacer un checkeo de la fecha que solicita el usuario,
    # para saber si es requerida la taza de este mes o del mes anterior
    def validar_fecha
        if @fecha.day < 15
            @fecha = @fecha - 1.month
        end
    end

end

## Despues de unas cuantas request, me di cuenta que estos eran los tipos de operaciones habilitadas,
## en base a esto y lo que se solicitaba en el ejercicio es que se hace el metodo tipos_operaciones
# "Tipo": "21" operaciones reajustables pesos < año
# "Tipo": "22" operaciones reajustables pesos > año, UF > 2k
# "Tipo": "24" operaciones reajustables pesos > año, UF <= 2k
# "Tipo": "25" operaciones NO reajustables pesos < 90 dias, UF > 5k
# "Tipo": "26" operaciones NO reajustables pesos < 90 dias, UF <= 5k
# "Tipo": "34" operaciones NO reajustables pesos >= 90 dias, UF > 5k
# "Tipo": "35" operaciones NO reajustables pesos >= 90 dias, UF <= 5k & UF > 200
# "Tipo": "41" operaciones extranjeras $$US$$ <= UF 2k
# "Tipo": "42" operaciones extranjeras $$US$$ > UF 2k
# "Tipo": "43" --- no tengo idea, pero no tengo como calcularlo con los parametros --
# "Tipo": "44" operaciones NO reajustables pesos >= 90 dias, UF > 50 & UF < 200
# "Tipo": "45" operaciones NO reajustables pesos >= 90 dias, UF < 50

