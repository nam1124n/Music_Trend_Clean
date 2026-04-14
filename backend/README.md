# Backend

This project uses Phoenix with Elixir `1.19.5` and Erlang/OTP `28.1`.

If your shell still points to the system Elixir, use the local helper scripts in `bin/`.
The scripts also keep `Mix` and `Hex` state inside this project (`.mix/` and `.hex/`) so they do not depend on a broken global Hex install.

## Quick start

Install deps and create the SQLite database:

```bash
./bin/setup
```

Start the Phoenix server:

```bash
./bin/dev
```

Open [`http://localhost:4000`](http://localhost:4000).

## If `mix` is using the wrong runtime

Check the active toolchain:

```bash
./bin/run-with-elixir elixir --version
./bin/run-with-elixir mix --version
./bin/run-with-elixir erl -noshell -eval 'io:format("~s~n", [erlang:system_info(otp_release)]), halt().'
```

All three commands should report Elixir `1.19.5` and OTP `28`.
