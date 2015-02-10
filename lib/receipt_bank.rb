require 'byebug'
require "json"
require 'faraday'
require "receipt_bank/version"
require "receipt_bank/errors"
require "receipt_bank/responses"
require "receipt_bank/modules/user_authentication"
require "receipt_bank/modules/single_sign_on"
require "receipt_bank/modules/account_management"
require "receipt_bank/client"
require "receipt_bank/models/base_model"
require "receipt_bank/models/user"
require "receipt_bank/models/receipt"
require "receipt_bank/models/project"
require "receipt_bank/models/client"
require "receipt_bank/models/category"
require "receipt_bank/models/payee"
require "receipt_bank/models/country"
require "receipt_bank/models/currency"
require "receipt_bank/models/bank_account"

module ReceiptBank
  URI_API_USER = '/api/users'
  URI_OAUTH_TOKEN = '/oauth/login_token'
  URI_SSO = '/sso/login'
end