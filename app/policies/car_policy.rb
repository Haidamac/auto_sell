class CarPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.present? && user.admin?
        scope.all
      elsif user.present? && user.participant?
        scope.where(status: 'approved').or(scope.where(user_id: user.id))
      else
        scope.where(status: 'approved')
      end
    end
  end

  class EditScope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.participant?
        scope.where(user_id: user.id)
      end
    end
  end

  def permitted_attributes
    if user.admin?
      [:status]
    elsif user.participant?
      [:brand, :car_model, :body, :mileage, :color, :price, :fuel, :year, :volume, :user_id,
       { images: [] }]
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.participant?
  end

  def update?
    true
  end

  def destroy?
    true
  end
end
