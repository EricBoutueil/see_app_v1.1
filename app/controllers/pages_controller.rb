class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :cgu]

  def home
  end
end
