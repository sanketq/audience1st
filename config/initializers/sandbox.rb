# are we operating in 'sandbox' mode?  if so, some features like
# "real" CC purchases and email sending are turned off or
# handled differently.
SANDBOX = (RAILS_ENV != 'production'  ||
           Option.value(:sandbox).to_i != 0)
if SANDBOX
  ActionMailer::Base.delivery_method = :test
end