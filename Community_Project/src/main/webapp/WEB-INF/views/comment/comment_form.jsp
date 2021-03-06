<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form"  prefix="form" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<c:set var="rootPath" value="${pageContext.request.contextPath}"/>
<form class="cmt_form" method="POST" autocomplete="${FORM_AUTOCOMPLETE}">
	<sec:authorize access="hasAnyRole('ADMIN','USER')">
		<input class="cmt_csrf" name="${_csrf.parameterName}" value="${_csrf.token}" type="hidden">
	</sec:authorize>
	<input name="cmt_no" value="0" type="hidden">
	<input name="cmt_board_no" value="0" type="hidden">
	<input name="cmt_p_no" value="0" type="hidden">
	
	<article class="cmt_write_box">
		<div class="cmt_write_group cmt_nickname">
			<sec:authorize access="isAuthenticated()">
				<span><sec:authentication property="principal.nickname"/></span>
			</sec:authorize>
		</div>
		
		<div class="cmt_write_group">
			<sec:authorize access="isAuthenticated()">
				<textarea class="form-control cmt_content" name="cmt_content" rows="2"></textarea>
			</sec:authorize>
			<sec:authorize access="!isAuthenticated()">
				<textarea class="form-control cmt_content_unauth" rows="2" placeholder="댓글을 달려면 로그인해야 합니다." readonly></textarea>
			</sec:authorize>
		</div>
	</article>
	
	<article class="cmt_btn_box">
		<button class="btn_cmt_cancel btn_red" type="button">취소</button>
		<button class="btn_cmt_save btn_blue" type="button">등록</button>
	</article>
</form>