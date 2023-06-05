<script>
    import { Tabs, Tab, TabLabel, TabContent } from './Tabs';

    const apiUrl = "/api";

    let fields = {
        "plaintext": "",
        "crypt": "",
        "cryptfile": "",
        "pass": "",
        "uuid": "",
        "XChaCha20Poly1305": "",
    }

    function debounce(func, wait) {
        var timeout;
        return function() {
            var context = this, args = arguments;
            var later = function() {
                timeout = null;
                func.apply(context, args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    };

    const cryptPlaintext = debounce(event => {
        genService("crypt", {
            method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({secret: event.target.value})
        }).apply();
    }, 300)

    const cryptFile = debounce(event => {
        var payload = new FormData();

        payload.append("file", event.target.files[0], "file");
        genService("cryptfile", {
            method: "POST",
            body: payload
        }).apply();
    }, 300)

    function genService(service, args = {}) {
        return async function(e) {
            fields[service] = "Waiting...";
            const res = await fetch(apiUrl + `/` + service, args);
            const pass = await res.json();

            if (res.ok) {
                fields[service] = pass.secret;
            } else {
                fields[service] = "Error...";
            }
        }
    }

    function switchTab(event) {
        switch(event.detail.tab) {
        case 3:
            genService("pass").apply();
            break;
        case 4:
            genService("uuid").apply();
            break;
        case 5:
            genService("XChaCha20Poly1305").apply();
            break;
        }
    }
</script>

<style>
 :global(body) {
     background: linear-gradient(45deg,#ff8737 29.25%,#f60 100%) no-repeat fixed;
     background-color: #f90;
 }

 h1 {
     color: white;
     text-transform: uppercase;
     text-align: center;
     font-size: 4em;
     font-weight: 100;
 }

 input {
     width: 100%;
     font-size: 0.95em;
 }
</style>

<h1>Luccryptous</h1>

<Tabs>
  <Tab on:switch={switchTab}>
    <TabLabel>Chiffrer</TabLabel>
    <TabContent>
      <label>
        <h3>Plaintext :</h3>
        <input on:input={cryptPlaintext}>
      </label>
      <label>
        <h3>Ciphertext :</h3>
        <input readonly value={fields.crypt} on:click={navigator.clipboard.writeText(fields.crypt)}>
      </label>
    </TabContent>
  </Tab>
  <Tab on:switch={switchTab}>
    <TabLabel>Chiffrer fichier</TabLabel>
    <TabContent>
      <label>
        <h3>File :</h3>
        <input type="file" on:input={cryptFile} multiple="false">
      </label>
      <label>
        <h3>Ciphertext :</h3>
        <input readonly value={fields.cryptfile} on:click={navigator.clipboard.writeText(fields.cryptfile)}>
      </label>
    </TabContent>
  </Tab>
  <Tab on:switch={switchTab}>
    <TabLabel>Password</TabLabel>
    <TabContent>
      <label>
        <h3>Ciphertext :</h3>
        <input readonly value={fields.pass} on:click={navigator.clipboard.writeText(fields.pass)}>
      </label>
      <button on:click={genService(`pass`)}>Regénérer</button>
    </TabContent>
  </Tab>
  <Tab on:switch={switchTab}>
    <TabLabel>UUID</TabLabel>
    <TabContent>
      <label>
        <h3>Ciphertext :</h3>
        <input readonly value={fields.uuid} on:click={navigator.clipboard.writeText(fields.uuid)}>
      </label>
      <button on:click={genService(`uuid`)}>Regénérer</button>
    </TabContent>
  </Tab>
  <Tab on:switch={switchTab}>
    <TabLabel>XChaCha20Poly1305 Key</TabLabel>
    <TabContent>
      <label>
        <h3>Ciphertext :</h3>
        <input readonly value={fields.XChaCha20Poly1305} on:click={navigator.clipboard.writeText(fields.XChaCha20Poly1305)}>
      </label>
      <button on:click={genService(`XChaCha20Poly1305`)}>Regénérer</button>
    </TabContent>
  </Tab>
</Tabs>
