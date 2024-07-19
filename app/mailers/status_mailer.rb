class StatusMailer < ApplicationMailer
  def car_approved(user, car)
    @user = user
    @car = car
    mail(to: @user.email, subject: 'Публікацію Вашого оголошення схвалено адміністратором')
  end

  def car_rejected(user, car)
    @user = user
    @car = car
    mail(to: @user.email, subject: 'Публікацію Вашого оголошення відхилено адміністратором')
  end
end
