Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer
  provider :identity, :fields => [:email], on_failed_registration: lambda { |env|
    CustomersController.action(:new).call(env)
  }, model: Authorization, locate_conditions: lambda{|req| {model.auth_key => req['email']}}
end