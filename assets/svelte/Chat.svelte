<script>
    import { onMount, afterUpdate } from "svelte";
    import { SvelteToast, toast } from '@zerodevx/svelte-toast';

    export let live;

    let username = null;
    let messages = [];
    let newMessage = "";
    let usernameInput = "";
    let chatContainer;

    onMount(() => {
        const storedUsername = localStorage.getItem("username");
        if(storedUsername) {
            username = storedUsername;
        }

        live.handleEvent("add_message", (message) => {
            messages = [...messages, message];
        });

        live.handleEvent("notification", ({ message }) => {
            toast.push(message);
        });

        window.addEventListener("beforeunload", () => {
            live.pushEvent("user", { user: username, action: "leave" }, () => {});
        });
    });

    afterUpdate(() => {
        scrollToBottom();
    });

    function sendMessage() {
        if (newMessage.trim()) {
            let message = { user: username, text: newMessage };
            live.pushEvent("message", message, () => {});
            messages = [...messages, message];
            newMessage = "";
        }
    }

    function handleKeyDown(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            sendMessage();
        }
    }

    function setUsername(event) {
        if (event.key === 'Enter' || event.key === 'click') {
            if (usernameInput.trim()) {
                username = usernameInput;
                live.pushEvent("user", { user: username, action: "join" }, () => {});
                localStorage.setItem("username", username);
            }
        }
    }

    function scrollToBottom() {
        if (chatContainer) {
            chatContainer.scrollTop = chatContainer.scrollHeight;
        }
    }
</script>

<SvelteToast />
{#if username === null}
    <div class="flex flex-col items-center justify-center h-screen">
        <input
            type="text"
            placeholder="Escolha um nome"
            bind:value={usernameInput}
            on:keydown={setUsername}
            class="p-2 border border-gray-300 rounded-lg"
        />
        <button
            on:click={setUsername}
            class="mt-2 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
        >
            Entrar
        </button>
    </div>
{:else}
    <div class="flex flex-col h-screen">
        <div bind:this={chatContainer} class="flex-1 p-4 overflow-y-auto bg-gray-100 border rounded-lg max-h-[calc(100vh-200px)]">
            {#each messages as message}
                <div class="mb-2">
                    <div class="font-semibold">{message.user}</div>
                    <div class="p-2 bg-white rounded-lg shadow">{message.text}</div>
                </div>
            {/each}
        </div>

        <div class="flex mt-4">
            <input
                type="text"
                placeholder="Digite uma mensagem"
                bind:value={newMessage}
                on:keydown={handleKeyDown}
                class="flex-1 p-2 border border-gray-300 rounded-l-lg"
            />
            <button
                on:click={sendMessage}
                class="px-4 bg-blue-500 text-white rounded-r-lg hover:bg-blue-600"
            >
                Enviar
            </button>
        </div>
    </div>
{/if}
