class UsersController < ProjectController
  has_many :projects, through: :user_project

  def show
  end

  def destroy_project
    # 親のdestroyを呼び出す
    public_method(:destroy).super_method.call
  end

  def new
    @project = Project.new
  end

end
