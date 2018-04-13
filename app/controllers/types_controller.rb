class TypesController < ApplicationController

  def index
    @types = policy_scope(Type)
  end
end
