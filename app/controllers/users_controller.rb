class UsersController < ProjectsController
  def show
  end

  def destroy
    # 親のdestroyを呼び出す
    public_method(:destroy).super_method.call
  end

  def new
    @project = Project.new
  end

end
