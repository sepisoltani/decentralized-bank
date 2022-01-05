<template>
  <div id="app">
    <div class="container">

      <nav>
        <div class="nav nav-tabs" id="nav-tab" role="tablist">
          <button class="nav-link active" id="nav-deposit-tab" data-bs-toggle="tab" data-bs-target="#nav-deposit"
                  type="button" role="tab" aria-controls="nav-deposit" aria-selected="true">deposit
          </button>
          <button class="nav-link" id="nav-withdraw-tab" data-bs-toggle="tab" data-bs-target="#nav-withdraw"
                  type="button" role="tab" aria-controls="nav-withdraw" aria-selected="false">withdraw
          </button>
        </div>
      </nav>


      <div class="tab-content" id="nav-tabContent">
        <div class="tab-pane fade show active" id="nav-deposit" role="tabpanel" aria-labelledby="nav-deposit-tab">
          <div class="p-2">
            <strong>How much do you want to deposit?</strong>
            <br>
            <label>
              <input v-model="depositFormAmount" placeholder="min amount is 0.01 ETH" id="depositInput" type="number"
                     class="form-control mt-5 form-control-lg" required>
              <br>
              <button @click="deposit" class="btn btn-primary btn-sm">deposit</button>
            </label>
          </div>
        </div>
        <div class="tab-pane fade" id="nav-withdraw" role="tabpanel" aria-labelledby="nav-withdraw-tab">
          <div class="p-2">
            <strong>Do you want to take profit and withdraw?</strong>
            <br>
            <button @click="withdraw" class="btn btn-primary mt-5 btn-sm">withdraw</button>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
import Web3 from 'web3'
import Token from '../../build/contracts/DBC.json'
import Dbank from '../../build/contracts/Bank.json'

export default {
  name: 'App',
  data() {
    return {
      depositFormAmount: 0.01,
      web3: {},
      netId: 0,
      accounts: [],
      balance: 0,
      token: null,
      dbank: null,
      dbankAddress: null
    }
  },
  async created() {
    await this.loadWeb3()
    await this.getNetId()
    await this.getAccounts()
    await this.getBalance(this.accounts[0])
    this.getContracts()

  },
  methods: {
    async loadWeb3() {
      if (typeof window.ethereum !== "undefined") {
        try {
          // Request account access if needed
          await window.ethereum.enable();
        } catch (error) {
          return alert("user denied")
        }
        this.web3 = new Web3(window.ethereum);
      } else {
        return alert("please install metamask")
      }
    },
    async getNetId() {
      this.netId = await this.web3.eth.net.getId()
      console.log(this.netId)
    },
    async getAccounts() {
      this.accounts = await this.web3.eth.getAccounts()
      console.log(this.accounts)
    },
    async getBalance(account) {
      this.balance = await this.web3.eth.getBalance(account)
      console.log(this.balance)
    },
    getContracts() {
      this.token = new this.web3.eth.Contract(Token.abi, Token.networks[this.netId].address)
      console.log(this.token)
      this.dbank = new this.web3.eth.Contract(Dbank.abi, Dbank.networks[this.netId].address)
      console.log(this.dbank)
      this.dbankAddress = Dbank.networks[this.netId].address
      console.log(this.dbankAddress)
    },
    async deposit() {
      const amount = this.depositFormAmount * 10 ** 18 // conver to wei
      await this.dbank.methods.deposit().send({value: amount, from: this.accounts[0]})
    },
    async withdraw() {
      await this.dbank.methods.withdraw().send({from: this.accounts[0]})
    }
  }
}
</script>
<style>
@import '~bootstrap/dist/css/bootstrap.min.css';
</style>
