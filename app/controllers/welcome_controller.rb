class WelcomeController < ApplicationController
  before_filter :login_required, :except => [:index]
end