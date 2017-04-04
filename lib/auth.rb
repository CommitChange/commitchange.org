require 'bcrypt'
require 'jwt'

module Auth

  # Authenticate a password given the email address of a user
  def self.user(email, plain_pass)
    user = Qx.fetch(:users, email: email).first
    return user && BCrypt::Password.new(user['encrypted_password']) == plain_pass
  end

  # JWT functionality
  # https://tools.ietf.org/html/rfc7519#section-4.1.1
  # https://github.com/jwt/ruby-jwt
  # Encode a user into a JWT auth token that can be passed to the client
  def self.encode(user)
    exp = Time.now.to_i + 14400 # Expire in 4hrs
    csrf_token = SecureRandom.uuid
    jwt = JWT.encode({
      iat: Time.now.to_i,
      iss: 'https://api.commitchange.com',
      exp: exp,
      sub: user['id'],
      email: user['email'],
      roles: user['roles'],
      csrf_token: csrf_token
    }, ENV['HMAC_SECRET'], 'HS256')

    return [jwt, csrf_token]
  end

  # Decode a JWT token -- will throw an exception if the token is
  # invalid/expired, which will get caught by the Sinatra router
  def self.decode(jwt, csrf_token)
    decoded = JWT.decode(jwt, ENV['HMAC_SECRET'], true, {algorithm: 'HS256'})
    decoded_csrf = decoded.first['csrf_token']
    raise InvalidCSRFToken.new("Please pass in a valid CSRF token") unless decoded_csrf.present? && csrf_token == decoded.first['csrf_token']
    return decoded
  end

  def self.generate_user_roles(user)
    roles = Qx.select("*").from(:roles).where({"user_id" => user['id']}).execute
    resp = {}
    resp['roles'] = []
    resp['roles'] = roles.map{|role| {name: role['name'], host_id: role['host_id'], host_type: role['host_type']}}
    return resp['roles']
  end
end

class InvalidCSRFToken < Exception
end
