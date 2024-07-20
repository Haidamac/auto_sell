class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(role: 'participant')
      end
    end
  end

  class EditScope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.participant?
        scope.where(id: user.id)
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

  def update?
    true
    # user.admin? || user == record
  end

  def destroy?
    Rails.logger.debug "User: #{user.inspect}"
    Rails.logger.debug "Record: #{record.inspect}"
    # user.admin? || user == record
    true
  end

  def create_admin?
    user.admin?
  end
end
