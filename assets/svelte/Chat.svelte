<script>
 import { onMount } from "svelte";
 export let live;

 let messages = [];
 let newMessage = "";

 onMount(() => {
     live.handleEvent("add_message", (message) => {
         messages = [ ...messages, message ]
     });
 });

 function sendMessage() {
     if(newMessage.trim()) {
         let message = { user: "raul", text: newMessage };
         live.pushEvent("message", message, () => {});
         messages = [ ...messages, message ];
         newMessage = "";
     }
 }

 function handleKeyDown(event) {
     if (event.key === 'Enter') {
         event.preventDefault();
         sendMessage();
     }
 }
</script>

<div class="flex flex-col h-screen">
    <div class="flex-1 p-4 overflow-y-auto bg-gray-100 border rounded-lg max-h-[calc(100vh-200px)]">
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
            placeholder="Digite uma mensagem..."
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
