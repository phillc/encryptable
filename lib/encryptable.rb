require "encryptable/railtie"

module Encryptable
  extend ActiveSupport::Concern

  included do
    @encrypted_attributes = {}
  end

  class_methods do
    attr_reader :encrypted_attributes

    def encrypt_attributes(*attributes, type: nil)
      attributes.each do |attribute|
        define_method(attribute) do
          (instance_variable_defined?("@#{attribute}") && instance_variable_get("@#{attribute}")) ||
            instance_variable_set("@#{attribute}", read_encrypted_attribute(attribute))
        end

        define_method("#{attribute}=") do |value|
          typed_value = write_encrypted_attribute(attribute, value)

          instance_variable_set("@#{attribute}", typed_value)
        end

        define_method("#{attribute}?") do
          value = public_send(attribute)
          value.respond_to?(:empty?) ? !value.empty? : !!value
        end

        @encrypted_attributes[attribute] = { type: type }
      end
    end

    def create_cipher
      OpenSSL::Cipher::AES256.new(:gcm).tap do |cipher|
        key = Rails.application.secrets.encryption_cipher_key.presence
        raise "No Cipher key" unless key
        cipher.key = key
      end
    end
  end


  def read_encrypted_attribute(attribute)
    encrypted_value = public_send("#{attribute}_encrypted")
    return unless encrypted_value
    cipher = self.class.create_cipher
    cipher.decrypt
    cipher.iv = public_send("#{attribute}_iv")
    result = cipher.update(encrypted_value)
    if type = type_for_encrypted_attribute(attribute)
      result = type.cast(result)
    end

    result
  end

  def write_encrypted_attribute(attribute, given_value)
    if (type = type_for_encrypted_attribute(attribute))
      typed_value = type.cast(given_value)
      coerced_value = type.serialize(given_value).presence&.to_s(:db)
    else
      coerced_value = given_value.presence&.to_s
    end

    if coerced_value.blank?
      iv = nil
      result = nil
    else
      cipher = self.class.create_cipher
      cipher.encrypt
      iv = cipher.random_iv
      result = cipher.update(coerced_value)
    end

    public_send("#{attribute}_encrypted=", result)
    public_send("#{attribute}_iv=", iv)
    (type && typed_value) || coerced_value
  end

  def type_for_encrypted_attribute(attribute)
    if type_name = self.class.encrypted_attributes[attribute.to_sym][:type]
      ActiveModel::Type.const_get(type_name.to_s.classify).new
    end
  end
end
