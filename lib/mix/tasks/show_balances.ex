defmodule Mix.Tasks.Show.Balances do
  use Mix.Task
  import Mix.Ecto
  import Mix.Tasks.Helpers
  import Cryptozaur.{Utils, Logger}
  alias TableRex.Table
  alias Cryptozaur.{Repo, Connector, DriverSupervisor}

  @shortdoc "Show balances"

  def run(args) do
    %{flags: %{verbose: _verbose}, options: %{config_filename: config_filename, accounts_filename: accounts_filename}, args: %{account_name: account_name, currency: currency}} = parse_args(args)
    ensure_repo(Repo, [])
    {:ok, _pid, _apps} = ensure_started(Repo, [])
    {:ok, _pid} = Application.ensure_all_started(:httpoison)
    {:ok, _pid} = Application.ensure_all_started(:ex_rated)
    {:ok, _pid} = DriverSupervisor.start_link([])

    {:ok, _config} = read_json(config_filename)
    {:ok, accounts} = read_json(accounts_filename)

    result =
      with {:ok, %{exchange: exchange, key: key, secret: secret}} <- get_account(account_name, accounts),
           {:ok, balances} <- Connector.get_balances(exchange, key, secret) do
        balances =
          if currency do
            balances |> Enum.filter(&(&1.currency == currency))
          else
            balances |> Enum.filter(&(&1.total_amount != 0.0))
          end

        balances
        |> Enum.sort_by(& &1.currency)
        |> Enum.map(&[&1.currency, &1.wallet, format_amount(exchange, &1.currency, "BTC", &1.available_amount), format_amount(exchange, &1.currency, "BTC", &1.total_amount)])
        |> Table.new(["Currency", "Wallet", "Available", "Total"])
        |> Table.put_column_meta(2..5, align: :right)
        |> Table.render!()
        |> Mix.shell().info()

        {:ok, balances}
      end

    case result do
      {:ok, value} -> {:ok, value}
      {:error, error} -> Mix.shell().info("[ERR] " <> to_verbose_string(error))
    end

    result
  end

  def validate_account_name_unique(name, accounts) do
    case !Map.has_key?(accounts, String.to_atom(name)) do
      true -> {:ok, true}
      false -> {:error, %{message: "Account already exists", name: name}}
    end
  end

  def validate_credentials(exchange, key, secret) do
    case Connector.credentials_valid?(exchange, key, secret) do
      {:ok, true} -> {:ok, true}
      {:error, reason} -> {:error, %{message: "Invalid credentials: request for balances failed", reason: reason}}
    end
  end

  def parse_args(argv) do
    Optimus.new!(
      allow_unknown_args: false,
      parse_double_dash: true,
      args: [
        account_name: [
          value_name: "account",
          help: "Account name",
          required: true
        ],
        currency: [
          value_name: "currency",
          help: "Currency",
          required: false
        ]
      ],
      flags: [
        verbose: [
          value_name: "verbose",
          short: "-v",
          long: "--verbose",
          help: "Print extra information",
          required: false
        ]
      ],
      options: [
        config_filename: [
          value_name: "config_filename",
          short: "-c",
          long: "--config",
          help: "Config filename",
          default: "#{System.user_home!()}/.cryptozaur/config.json",
          required: false
        ],
        accounts_filename: [
          value_name: "accounts_filename",
          short: "-u",
          long: "--accounts",
          help: "Accounts filename",
          default: "#{System.user_home!()}/.cryptozaur/accounts.json",
          required: false
        ]
        #        without_dust: [
        #          value_name: "without_dust",
        #          short: "-d",
        #          long: "--without-dust",
        #          help: "Without dust (dust amount is specified in config)",
        #          default: false,
        #          required: false
        #        ],
      ]
    )
    |> Optimus.parse!(argv)
  end
end
