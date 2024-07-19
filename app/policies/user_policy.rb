class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.participant?
        scope.where(id: user.id)
      else
        scope.none
      end
    end
  end

  def index?
    user.admin?
  end

  def show?
    true
  end

  def create?
    true
  end

  def destroy?
    true
  end

  def create_admin?
    user.admin?
  end
end
