module Authenticate
  def current_user
    header = request.headers['Authorization']
    return unless header

    token = header.split(' ').last
    decoded = jwt_decode(token)
    @current_user = User.find(decoded[:user_id])
  end
end
