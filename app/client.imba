import { SplitAttentionPage } from "./splitAttention/splitAttention.imba"

global css html
	ff:sans

tag app
	<self>
		<a route-to="/"> "Home"
		<div route="/splitAttention$"> <SplitAttentionPage>
		<div route="/$">
			<a route-to="./splitAttention"> "Split Attention"

imba.mount <app>