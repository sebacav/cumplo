require 'test_helper'

class CreditsControllerTest < ActionDispatch::IntegrationTest

  test "Al consultar GET /credits/:uf/:dias/:fecha deberia arrojar un error 400, si envío una fecha incorrecta" do
    get "/credits/5000/366/2020-12-40", as: :json
    assert_response :bad_request
  end

  test "Al consultar GET /credits/:uf/:dias/:fecha deberia arrojar un error 400, si envío dias no numericos" do
    get "/credits/5000/bad_test/2020-12-40", as: :json
    assert_response :bad_request
  end

  test "Al consultar GET /credits/:uf/:dias/:fecha deberia arrojar un error 400, si envío una uf no numerica" do
    get "/credits/bad_test/366/2020-12-40", as: :json
    assert_response :bad_request
  end

  # Se comenta el test, debido a que la API de la SBIF no funciona muy bien. 

  # test "Al consultar GET /credits/:uf/:dias/:fecha deberia arrojar un status 200, si se envian todos los campos correctamente" do
  #   get "/credits/5000/366/2020-07-05", as: :json
  #   assert_response :ok
  # end

end