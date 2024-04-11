defmodule SFDCQuery.RestAPITest do
  use ExUnit.Case

  alias SFDCQuery.RestAPI

  describe "query/2" do
    setup do
      %{
        instance_url: "https://my_sfdc_instance.salesforce.com",
        access_token: "MY_ACCESS_TOKEN",
        version: "60.0"
      }
    end

    test "returns the records when successful", args do
      records = [
        %{"Id" => "001U8000005CeutIAC"},
        %{"Id" => "001U8000005cJN0IAM"},
        %{"Id" => "001U8000005cRAnIAM"},
        %{"Id" => "001U8000005oz2rIAA"}
      ]

      Mimic.expect(Req, :request, fn method: :get,
                                     url: "https://my_sfdc_instance.salesforce.com/services/data/v60.0/query",
                                     headers: [{"Authorization", "Bearer MY_ACCESS_TOKEN"}],
                                     params: [q: "SELECT Id From Account LIMIT 10"] ->
        {:ok,
         %Req.Response{
           status: 200,
           body: %{
             "done" => true,
             "records" => records,
             "totalSize" => 4
           }
         }}
      end)

      assert {:ok, ^records} =
               args
               |> SFDCQuery.Client.Default.create()
               |> SFDCQuery.query("SELECT Id From Account LIMIT 10")
    end

    test "returns error when failed", args do
      reason = %Req.Response{status: 400}

      Mimic.expect(Req, :request, fn method: :get,
                                     url: "https://my_sfdc_instance.salesforce.com/services/data/v60.0/query",
                                     headers: [{"Authorization", "Bearer MY_ACCESS_TOKEN"}],
                                     params: [q: "SELECT Id From Account LIMIT 10"] ->
        {:error, reason}
      end)

      assert {:error, ^reason} =
               args
               |> SFDCQuery.Client.Default.create()
               |> SFDCQuery.query("SELECT Id From Account LIMIT 10")
    end
  end
end
