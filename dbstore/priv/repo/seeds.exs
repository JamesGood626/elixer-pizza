alias Dbstore.Repo
alias Dbstore.{User, Pizza, Toppings, Permissions}

{:ok, user} =
  %User{}
  |> User.changeset(%{username: "user_one", password: "password"})
  |> Repo.insert()

Repo.insert!(%Permissions{name: "PIZZA_APPLICATION_MAKER"})
Repo.insert!(%Permissions{name: "PIZZA_OPERATION_MANAGER"})
Repo.insert!(%Permissions{name: "PIZZA_CHEF"})

pizza = Repo.insert!(%Pizza{name: "Cheese Olive"})
pepperoni = Repo.insert!(%Toppings{name: "Pepperoni"})
pineapple = Repo.insert!(%Toppings{name: "Pineapple"})
olives = Repo.insert!(%Toppings{name: "Olives"})

Repo.insert_all("pizza_toppings", [
  [
    pizza_id: pizza.id,
    topping_id: pepperoni.id,
    inserted_at: ~N[2019-06-27 16:54:00],
    updated_at: ~N[2019-06-27 16:54:00]
  ],
  [
    pizza_id: pizza.id,
    topping_id: pineapple.id,
    inserted_at: ~N[2019-06-27 16:54:00],
    updated_at: ~N[2019-06-27 16:54:00]
  ],
  [
    pizza_id: pizza.id,
    topping_id: olives.id,
    inserted_at: ~N[2019-06-27 16:54:00],
    updated_at: ~N[2019-06-27 16:54:00]
  ]
])

IO.puts("Success! Sample data has been added.")
