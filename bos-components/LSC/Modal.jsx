State.init({
	tokens: [],
	search: ""
});

if (
	props.chainData == undefined || 
	props.contractABI == undefined
) {
	return (<></>);
}

const ModalStyle = styled.div`
	.show {
		opacity: 1 !important;
		visibility: visible !important;
		pointer-events: auto !important;
		backdrop-filter: blur(5px);
	}

	.basemodal {
		position: fixed;
		display: flex;
		justify-content: center;
		align-items: center;
		inset: 0;
		opacity: 0;
		visibility: hidden;
		transition: all 0.15s linear !important;
		pointer-events: none;
		& > div {
			width: 50%;
			height: 50%;
			padding: 1rem;
			position: absolute;
		}
	}

	.buttonhover {
		&:hover {
			color: var(--bs-gray-800) !important;
		}
	}
	button:focus {
		outline: none !important;
		box-shadow: none !important;
	}
`;
const CloseButton = styled.button`
  border: 0;
  color: var(--bs-gray-600);
  transition: color 0.15s ease-in-out;
`;

const loadFutures = () => {
	const ctr = new ethers.Contract(
		props.chainData.contractAddress,
		props.contractABI,
		Ethers.provider().getSigner()
	);
	ctr.getFutureNames().then((test) => {
		const tkns = Array.from(test, (tkn, i) => ethers.utils.parseBytes32String(tkn));
		if (state.search != "") {
			State.update({ tokens: Array.from(tkns, (tkn, i) => tkn.includes(state.search) ? tkn : null).filter((x) => x != null)});
		} else {
			State.update({ tokens: tkns });
		}
	});
};
loadFutures();

const onSearch = (e) => {
	State.update({ search: e.target.value });
	loadFutures();
};

const modalId = (Math.random() + 1).toString(36).substring(7);
const onCloseBtnClick = (e) => {
	if (e.target.id !== modalId) return;
	props.onClose();
};


return (<ModalStyle>
	<div className={"modal basemodal" + (props.show ? " show" : "")} id={modalId} onClick={onCloseBtnClick}>
		<div className="d-flex flex-column rounded bg-light shadow-sm" onClick={(e) => console.log(e.type)}>
			<div className="d-flex flex-row-reverse">
				<CloseButton className="buttonhover" onClick={props.onClose}>
					<svg
						width="30"
						height="30"
						viewBox="0 0 20 20"
						fill="none"
						xmlns="http://www.w3.org/2000/svg"
					>
						<path
						d="M15.5 5L5.5 15M5.5 5L15.5 15"
						stroke="currentColor"
						strokeWidth="1.66667"
						strokeLinecap="round"
						strokeLinejoin="round"
						/>
					</svg>
				</CloseButton>
			</div>
			<input className="form-control mt-2" type="text" placeholder="🔎 Search" aria-label="Search" onChange={(e) => onSearch(e)}/>
			<div className="table-responsive mt-3 rounded">
				<table className="table table-hover m-0">
					<thead>
						<tr>
							<th scope="col">#</th>
							<th scope="col">Name</th>
						</tr>
					</thead>
					<tbody>
						{Array.from(state.tokens).map((tkn, i) => (<tr key={i} onClick={() => props.onSelect(tkn)} style={(props.selected != tkn) || (props.selected == undefined) ? { cursor: "pointer" } : {}}>
							<th scope="row">{i}</th>
							<td>{tkn}</td>
						</tr>))}
					</tbody>
				</table>
			</div>
		</div>
	</div>
</ModalStyle>);
