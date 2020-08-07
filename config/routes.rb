Rails.application.routes.draw do

  # Ruta del controlador que nos permite obtener el credito basado en tmc
  get     '/credits/:uf/:dias/:fecha',             to: 'credits#tmc'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
