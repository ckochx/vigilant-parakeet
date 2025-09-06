defmodule Gearflow.Issues.Request do
  use Ecto.Schema
  import Ecto.Changeset

  schema "requests" do
    field :description, :string
    field :priority, :string
    field :status, :string
    field :attachments, {:array, :string}
    field :needed_by, :date
    field :equipment_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [:description, :priority, :status, :attachments, :needed_by, :equipment_id])
    |> validate_conditional_description()
    |> validate_inclusion(:priority, ["urgent", "high", "medium", "low"],
      message: "must be one of: urgent, high, medium, low"
    )
    |> maybe_put_defaults()
  end

  defp validate_conditional_description(changeset) do
    attachments = get_change(changeset, :attachments) || []
    description = get_change(changeset, :description)

    # Check if any attachments are audio files (voice memos)
    has_voice_memo = Enum.any?(attachments, &is_audio_file?/1)

    if has_voice_memo or (not is_nil(description) and String.trim(description) != "") do
      changeset
    else
      validate_required(changeset, [:description])
    end
  end

  defp is_audio_file?(file_path) when is_binary(file_path) do
    file_path
    |> Path.extname()
    |> String.downcase()
    |> case do
      ext when ext in [".mp3", ".m4a", ".wav", ".ogg", ".webm"] -> true
      _ -> false
    end
  end

  defp maybe_put_defaults(changeset) do
    changeset
    |> put_change(:status, get_change(changeset, :status) || "pending")
    |> put_change(:attachments, get_change(changeset, :attachments) || [])
  end
end
