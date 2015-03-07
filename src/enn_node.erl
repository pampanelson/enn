-module(enn_node).

%% API
-export([new/1, add_source/3, add_target/2, activate/2, backup/1,
         to_weight/1]).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.



%%%----------------------------------------
%%% API
%%%----------------------------------------

new(Pid) when is_pid(Pid) -> Pid;
new({M, F, A}) -> new(apply(M, F, A));
new({Std, A}) when is_atom(Std), is_list(A) ->
    new({stdnode(Std), new, A}).


add_source(N, S, W) when is_pid(N), is_pid(S) ->
    N ! {S, source, to_weight(W)},
    add_target(S, N).

add_target(N, T) when is_pid(N), is_pid(T) ->
    N ! {T, target},
    ok.

activate(N, A) when is_pid(N), is_float(A) ->
    N ! {self(), activity, A},
    ok;
activate(N, A) when is_pid(N) ->
    activate(N, to_weight(A)).

backup(N) when is_pid(N) ->
    N ! {self(), backup},
    receive
        {N, backup, B} -> B
    after
        100 ->
            throw({timeout, {backup, N}})
    end.

to_weight(N) when is_number(N) -> float(N);
to_weight(random) -> random:uniform() - random:uniform();
to_weight({M, F, A}) -> to_weight(apply(M, F, A));
to_weight(none) -> none.


%%%----------------------------------------
%%% Internal
%%%----------------------------------------

stdnode(neuron) -> enn_neuron;
stdnode(sensor) -> enn_sensor;
stdnode(actuator) -> enn_actuator.
