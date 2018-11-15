require 'test_helper'

class Encryptable::Test < ActiveSupport::TestCase
  setup do
    @user = User.create!(password: "thedoorcode", date_of_birth: Date.new(2014, 3, 5))
    @user.reload
  end

  test "stores a list of encrypted attributes" do
    assert_equal User.encrypted_attributes.keys, [:password, :date_of_birth]
  end

  test "it can be nil, and is nil for blank" do
    assert_not_nil @user.password
    @user.password = nil
    assert_nil @user.password
    @user.save!

    user = User.first
    assert_nil user.password

    user.password = ""
    assert_nil user.password
    user.save!

    user = User.first
    assert_nil user.password
  end

  test "it should be encrypted" do
    @user.password = "the_door_code"
    @user.save!

    user = User.first
    assert_not_nil user.password_encrypted
    assert_operator user.password_encrypted.size, :>, 1
    assert_not_equal user.password_encrypted, "the_door_code"
    assert_not_nil user.password_iv
    assert_equal user.password_iv.size, 12
    assert_equal user.password, "the_door_code"
  end

  test "it changes the underlying value even if same value is assigned to avoid leaking" do
    @user.password = @user.password
    assert @user.password_encrypted_changed?
    assert @user.password_iv_changed?
  end

  test "it types date of birth" do
    @user.date_of_birth = "2018-01-01"
    assert_kind_of Date, @user.date_of_birth
    @user.save!
    @user.reload
    assert_kind_of Date, @user.date_of_birth
    assert_equal @user.date_of_birth, Date.parse("2018-01-01")

    @user.date_of_birth = Date.parse("2000-02-02")
    assert_kind_of Date, @user.date_of_birth
    @user.save! validate: false
    @user.reload
    assert_kind_of Date, @user.date_of_birth
    assert_equal @user.date_of_birth, Date.parse("2000-02-02")

    @user.date_of_birth = DateTime.parse("2000-03-03")
    assert_kind_of Date, @user.date_of_birth
    @user.save! validate: false
    @user.reload
    assert_kind_of Date, @user.date_of_birth
    assert_equal @user.date_of_birth, Date.parse("2000-03-03")

    @user.date_of_birth = "blahblah"
    assert_nil @user.date_of_birth
    @user.save validate: false
    @user.reload
    assert_nil @user.date_of_birth
  end
end
