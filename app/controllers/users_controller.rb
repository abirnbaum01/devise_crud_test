class UsersController < ApplicationController
  
  load_and_authorize_resource #has cancan apply authorization 

  def index
     @users  = User.all
  end

  def show
     @user  = User.find(params[:id])
  end

  def new
     @user  = User.new
  end

  def edit
     @user  = User.find(params[:id])
  end

  def create
    @user  = User.new(user_params)

    if  @user .save
      redirect_to  @user , :flash => { :success => 'User was successfully created.' }
    else
      render :action => 'new'
    end
  end

  def update
    @user  = User.find(params[:id])


    # allows us to update the user without having to specify a new password and password confirmation each time by removing the password and password confirmation from the params hash if the password field is blank. So if you want to add other attributes to the user model in the future and allow users to change them on their own they can (without having to specify a password each time). 
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    # allows us to update a user to have no roles at all. Without this we would be forced to have at least one role checked when updating a user.
    params[:user][:role_ids] ||= []

    if  @user .update_attributes(user_params)
      sign_in( @user , :bypass => true) if  @user  == current_user
      redirect_to  @user , :flash => { :success => 'User was successfully updated.' }
    else
      render :action => 'edit'
    end
  end

  def destroy
     @user  = User.find(params[:id])
     @user .destroy
    redirect_to users_path, :flash => { :success => 'User was successfully deleted.' }
  end



  private

  #This tells the application to delete the :role_ids and :email keys from the user params hash unless the current user can :manage the user model as specified in app/models/ability.rb.
    def user_params
      if can? :manage, User
        params[:user]
      else
        params[:user].delete(:role_ids)
        params[:user].delete(:email)
    end
end

end
