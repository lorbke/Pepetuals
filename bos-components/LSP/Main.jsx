State.init({
	address: undefined,
	chainId: undefined,
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
		return Ethers.send("eth_requestAccounts", [])[0] ?? context.accountId;
	}
	return context.accountId;
};
if (getAccountId() !== null) {
	// TODO: causes error when near wallet???
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
if (!state.address) {
	return (<>
		<div className="spinner-border" role="status">
			<span className="visually-hidden">Loading...</span>
		</div>
	</>);
}

const getPositions = () => {
	const ctr = new ethers.Contract(
		JSON.parse(contractData.body)[state.chainId.toString()].contractAddress,
		contractABI.body,
		Ethers.provider().getSigner()
	);
	// ctr.getBalance({name: ethers.utils.formatBytes32String("OIL"), long: true, period: 1, leverage: 1}, state.address).then((test) => {
	// 	console.log(test);
	// });
	ctr.getPositions(state.address).then((test) => {

	});
};
const sellPosition = () => {
	const ctr = new ethers.Contract(
		JSON.parse(contractData.body)[state.chainId.toString()].contractAddress,
		contractABI.body,
		Ethers.provider().getSigner()
	);
	ctr.sell({name: ethers.utils.formatBytes32String("OIL"), long: true, period: 1, leverage: 1}, state.address).then((test) => {
		console.log(test);
	});
};

const MainStyle = styled.div`
	.btn:focus {
		outline: none !important;
		box-shadow: none !important;
	}
`;
return (
	<MainStyle>
		<div className="table-responsive mt-3 px-4 rounded">
			<table className="table table-hover m-0">
				<thead>
					<tr>
						<th scope="col">Name</th>
						<th scope="col">Long/Short</th>
						<th scope="col">Amount</th>
						<th scope="col">Perpetual</th>
						<th scope="col">Amount($)</th>
						<th scope="col">Sell</th>
					</tr>
				</thead>
				<tbody>
					{[...Array(50)].map((_, i) => (<tr key={i} onClick={onClose}>
						<th scope="row">OIL</th>
						<td>Long</td>
						<td>1.0</td>
						<td>True</td>
						<td>1.0</td>
						<td><button type="button" className="btn btn-primary" onClick={sellPosition}>Sell</button></td>
					</tr>))}
				</tbody>
			</table>
		</div>
	</MainStyle>
)