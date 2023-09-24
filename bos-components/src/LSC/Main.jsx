State.init({
	address: undefined,
	chainId: undefined,
	long: true,
	input: undefined,
	output: undefined,
	perpetual: false,
	leverage: 1,
	openModal: false,
	selectedOutput: undefined
});

const contractABI = fetch("https://raw.githubusercontent.com/lorbke/ETHGlobal-New-York/MultiLSP/contract_abi.json");
if (!contractABI.ok) {
	return (<>
		<div className="spinner-border" role="status">
			<span className="visually-hidden">Loading...</span>
		</div>
	</>);
}
const contractData = fetch("https://raw.githubusercontent.com/lorbke/ETHGlobal-New-York/MultiLSP/contract_data.json");
if (!contractData.ok) {
	return (<>
		<div className="spinner-border" role="status">
			<span className="visually-hidden">Loading...</span>
		</div>
	</>);
}

const getAccountId = () => {
	if (ethers !== undefined) {
		return Ethers.send("eth_requestAccounts", [])[0] ?? undefined;
	}
	return undefined;
};
if (getAccountId() != undefined) {
	Ethers.provider()
		.getNetwork()
		.then((chainIdData) => {
		if (chainIdData?.chainId) {
			State.update({
				address: getAccountId(),
				chainId: chainIdData.chainId,
			});
		}
	});
}

const approveOrder = () => {
	const ctr = new ethers.Contract(
		JSON.parse(contractData.body)[state.chainId.toString()].contractAddress,
		contractABI.body,
		Ethers.provider().getSigner()
	);
	const ctrusdc = new ethers.Contract(
		"0x07865c6E87B9F70255377e024ace6630C1Eaa37F",
		`[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_account","type":"address"}],"name":"unBlacklist","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"minter","type":"address"}],"name":"removeMinter","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_symbol","type":"string"},{"name":"_currency","type":"string"},{"name":"_decimals","type":"uint8"},{"name":"_masterMinter","type":"address"},{"name":"_pauser","type":"address"},{"name":"_blacklister","type":"address"},{"name":"_owner","type":"address"}],"name":"initialize","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"masterMinter","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"unpause","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"mint","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_amount","type":"uint256"}],"name":"burn","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"minter","type":"address"},{"name":"minterAllowedAmount","type":"uint256"}],"name":"configureMinter","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_newPauser","type":"address"}],"name":"updatePauser","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"paused","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"pause","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"minter","type":"address"}],"name":"minterAllowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"pauser","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_newMasterMinter","type":"address"}],"name":"updateMasterMinter","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"isMinter","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_newBlacklister","type":"address"}],"name":"updateBlacklister","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"blacklister","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"owner","type":"address"},{"name":"spender","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"currency","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_account","type":"address"}],"name":"blacklist","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_account","type":"address"}],"name":"isBlacklisted","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"minter","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"amount","type":"uint256"}],"name":"Mint","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"burner","type":"address"},{"indexed":false,"name":"amount","type":"uint256"}],"name":"Burn","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"minter","type":"address"},{"indexed":false,"name":"minterAllowedAmount","type":"uint256"}],"name":"MinterConfigured","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"oldMinter","type":"address"}],"name":"MinterRemoved","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"newMasterMinter","type":"address"}],"name":"MasterMinterChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_account","type":"address"}],"name":"Blacklisted","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_account","type":"address"}],"name":"UnBlacklisted","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"newBlacklister","type":"address"}],"name":"BlacklisterChanged","type":"event"},{"anonymous":false,"inputs":[],"name":"Pause","type":"event"},{"anonymous":false,"inputs":[],"name":"Unpause","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"newAddress","type":"address"}],"name":"PauserChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"previousOwner","type":"address"},{"indexed":false,"name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]`,
		Ethers.provider().getSigner()
	);
	ctr.buy({name: ethers.utils.formatBytes32String(state.selectedOutput), long: state.long, period: state.perpetual == true ? 4294967295 : 1, leverage: state.leverage}, state.input * 1e6).then((test) => {
		console.log(test);
	});
	// ctrusdc.approve(JSON.parse(contractData.body)[state.chainId.toString()].contractAddress, ethers.utils.parseEther(state.input)).then((test) => {
	// 	console.log(test);
	// 	ctr.buy({name: ethers.utils.formatBytes32String(state.selectedOutput), long: state.long, period: state.perpetual == true ? 4294967295 : 1, leverage: state.leverage}, ethers.utils.parseEther(state.input)).then((test) => {
	// 		console.log(test);
	// 	});
	// });
};

const MainStyle = styled.div`
	.btn:focus {
		outline: none !important;
		box-shadow: none !important;
	}
`
  
const ValueInput = styled.input`
	filter: none;
	opacity: 1;
	transition: opacity 0.2s ease-in-out 0s;
	text-align: left;
	font-size: 36px !important;
	line-height: 44px !important;
	font-variant: small-caps;
	color: rgb(13, 17, 28);
	// width: 0px;
	position: relative;
	font-weight: 400;
	outline: none;
	border: none;
	flex: 1 1 auto;
	background-color: transparent;
	white-space: nowrap;
	overflow: hidden !important;
	text-overflow: ellipsis;
	padding: 0px;
	appearance: textfield;
`;
const InputContainer = (text, inputstate, onClick) => {
	return (
		<div className="bg-light rounded p-2 d-flex">
			<ValueInput
				inputmode="decimal"
				autocomplete="off"
				autocorrect="off"
				type="text"
				pattern="^[0-9]*[.,]?[0-9]*$"
				placeholder="0"
				minlength="1"
				maxlength="9"
				spellcheck="false"
				value={state[inputstate]}
				onChange={(e) => State.update({ [inputstate]: e.target.value })}
			/>
			<button onClick={onClick} className="btn btn-secondary m-2 rounded-4" style={{ borderRadius: "25px", width: "130px" }} disabled={onClick == undefined}>{text}</button>
		</div>
	);
};

const ToggleDiv = styled.div`
	.toggle {
		position: relative;
		box-sizing: border-box;
	}
	.toggle input[type="checkbox"] {
		position: absolute;
		left: 0;
		top: 0;
		z-index: 10;
		width: 100%;
		height: 100%;
		cursor: pointer;
		opacity: 0;
	}
	.toggle label {
		position: relative;
		display: flex;
		align-items: center;
		box-sizing: border-box;
	}
	.toggle label:before {
		content: '';
		width: 75px;
		height: 42px;
		background: #ccc;
		position: relative;
		display: inline-block;
		border-radius: 46px;
		box-sizing: border-box;
		transition: 0.2s ease-in;
	}
	.toggle label:after {
		content: '';
		position: absolute;
		width: 38px;
		height: 38px;
		border-radius: 50%;
		left: 2px;
		top: 2px;
		z-index: 2;
		background: #fff;
		box-sizing: border-box;
		transition: 0.2s ease-in;
	}
	.toggle input[type="checkbox"]:checked + label:before {
		background: #4BD865;
	}
	.toggle input[type="checkbox"]:checked + label:after {
		left: 35px;
	}
`;
const ToggleSwitch = ({onChange, value}) => {
	return (
		<ToggleDiv>
			<div className="toggle">
				<input type="checkbox" onChange={onChange} checked={value}/>
				<label></label>
			</div>
		</ToggleDiv>
	)
};
  
return (<MainStyle>
	<Widget src="paulg00.testnet/widget/LSC.Modal" props={{
		chainData: state.chainId != undefined ? JSON.parse(contractData.body)[state.chainId.toString()] : undefined,
		contractABI: contractABI.body,
		show: state.openModal,
		onClose: () => State.update({ openModal: false }),
		selected: state.selectedOutput,
		onSelect: (token) => {
			State.update({ selectedOutput: token, openModal: false });
		}
	}}/>
	<div className="h-100 w-100 d-flex justify-content-center">
	  <div
		className="card shadow m-2 border-0"
		style={{
		  "--bs-bg-opacity": 0.25,
		  "--bs-border-opacity": 0.1,
		  width: "464px",
		  height: "462px",
		  borderRadius: "12px"
		}}
	  >
		<div className="card-body mx-auto d-flex flex-column justify-content-center w-100">
		  {state.address != undefined && (<div className="d-flex flex-column">
		  <div className="btn-group mb-3" role="group" aria-label="Basic example">
			<button type="button" className={"btn btn-primary" + (state.long == true ? " active" : "")} onClick={() => State.update({ long: true })}>
			  Long
			</button>
			<button type="button" className={"btn btn-primary" + (state.long != true ? " active" : "")} onClick={() => State.update({ long: false })}>
			  Short
			</button>
		  </div>
		  {InputContainer("USDC", "input", null)}
		  <div
			className="bg-light z-2 d-flex justify-content-center"
			style={{
			  margin: "-14px auto",
			  position: "relative",
			  borderRadius: "12px",
			  height: "40px",
			  width: "40px",
			  border: "5px solid rgb(255, 255, 255)",
			}}
		  >
			<div className="p-1 w-100 h-100 d-flex align-items-center justify-content-center">
			  <svg
				xmlns="http://www.w3.org/2000/svg"
				fill="#000000"
				height="800px"
				width="800px"
				version="1.1"
				id="Layer_1"
				viewBox="0 0 330 330"
			  >
				<path d="M325.607,79.393c-5.857-5.857-15.355-5.858-21.213,0.001l-139.39,139.393L25.607,79.393  c-5.857-5.857-15.355-5.858-21.213,0.001c-5.858,5.858-5.858,15.355,0,21.213l150.004,150c2.813,2.813,6.628,4.393,10.606,4.393  s7.794-1.581,10.606-4.394l149.996-150C331.465,94.749,331.465,85.251,325.607,79.393z" />
			  </svg>
			</div>
		  </div>
		  {InputContainer(state.selectedOutput == undefined ? "Select!" : state.selectedOutput, "output", () => State.update({ openModal: true }))}
		  <div className="d-flex justify-content-between align-items-center my-2">
			<label>Perpetual</label>
			<ToggleSwitch onChange={(e) => State.update({ perpetual: e.target.checked })} value={state.perpetual}/>
		  </div>
		  <div className="d-flex justify-content-between align-items-center my-2">
			<label>Leverage 2x</label>
			<ToggleSwitch onChange={(e) => State.update({ leverage: (e.target.checked == true ? 2 : 1) })} value={state.leverage == 2}/>
		  </div>
		  <button
			className="btn btn-primary mt-3"
			style={{ height: "50px" }}
			onClick={approveOrder}
			disabled={state.selectedOutput == undefined || state.input == undefined}
			>
			Approve Order
		</button>
		</div>)}
			<Web3Connect
				className={state.address == undefined ? "" : " d-none"}
				connectLabel="Connect with Web3"
			/>
		</div>
	  </div>
	</div>
</MainStyle>);  
