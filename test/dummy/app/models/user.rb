class User < ApplicationRecord
  include Encryptable

  encrypt_attributes :password
  encrypt_attributes :date_of_birth, type: :date
end
