class MovementPolicy < ApplicationPolicy
  class Scope < Scope # for index
    def resolve
      scope.all
      # scope ~ Restaurant
      # For a multi-tenant SaaS app, you may want to use:
      # scope.where(user: user)
    end
  end

  def index?
    user_is_admin?
  end

  def edit?  # => update
    user_is_admin?
  end

  def create? # => new
    user_is_admin?
  end

  def update?
    user_is_admin?
  end

  def destroy?
    user_is_admin?
  end

  private

  def user_is_admin?
    user.admin
  end
end
