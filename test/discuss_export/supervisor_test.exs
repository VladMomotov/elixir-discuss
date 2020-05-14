defmodule DiscussExport.SupervisorTest do
  use ExUnit.Case

  describe "start_link" do
    test "should start children" do
      {:ok, supervisor} = DiscussExport.Supervisor.start_link(nil)
      assert %{active: 3} = Supervisor.count_children(supervisor)
    end
  end
end
