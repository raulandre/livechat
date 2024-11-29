defmodule LiveChat.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :message, :string
    field :username, :string

    timestamps(type: :utc_datetime)
  end

  defimpl Jason.Encoder do
    def encode(%LiveChat.Chat.Message{message: message, username: username}, opts) do
      Jason.Encode.map(%{
            user: username,
            text: message
                       }, opts)
    end
  end

  @spec changeset(
          {map(),
           %{
             optional(atom()) =>
               atom()
               | {:array | :assoc | :embed | :in | :map | :parameterized | :supertype | :try,
                  any()}
           }}
          | %{
              :__struct__ => atom() | %{:__changeset__ => any(), optional(any()) => any()},
              optional(atom()) => any()
            },
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:message, :username])
    |> validate_required([:message, :username])
  end
end
