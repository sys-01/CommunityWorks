<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form"  prefix="form" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<c:set var="rootPath" value="${pageContext.request.contextPath}"/>
<style>
	.cmt_write_reply {
		display: none;
	}
	#btn_cmt_reply_save {
		border: 1px solid var(--color-dodgerblue);
		background-color: white;
		color: black;
		padding: 20px 30px;
	}
	#btn_cmt_reply_save:hover {
		background-color: var(--color-dodgerblue);
		color: white;
	}
</style>
<script>
	$(function() {
		let enable_btn_cmt_reply_save = true
		
		$(document).on("click", "#btn_cmt_reply_save", function() {
			if(!enable_btn_cmt_reply_save) return false
			
			if($("#cmt_reply_csrf").length == 0) {
				if(confirm("로그인 하시겠습니까?")) {
					document.location.href = "${rootPath}/user/login"
					return false
				} else {
					return false
				}
			}
			
			if($("#cmt_reply_content").val() == "") {
				alert("내용을 입력하세요.")
				return false
			}
			
			// 유효성 검사 통과 시
			// 서버 부하를 줄이기 위해 ajax 완료될 때까지 버튼 기능 끄기
			enable_btn_cmt_save = false
			$("body").css("cursor", "progress")
			
			$.ajax({
				url: "${rootPath}/comment/save",
				type: "POST",
				data: $("#comment_reply_form").serialize(),
				success: function(result) {
					$("#cmt_reply_content").val("")
					$(".cmt_write_reply").css("display", "none")
					$(".cmt_write_reply").appendTo(".cmt_reply_empty")
					$(".cmt_list").html(result)
				},
				error: function(error) {
					alert("서버 통신 오류")
				}
			}).always(function() {
				enable_btn_cmt_reply_save = true
				$("body").css("cursor", "default")
			})
		})
	})
</script>
<section class="cmt_write_reply">
	<form id="comment_reply_form" method="POST" autocomplete="${FORM_AUTOCOMPLETE}">
		<sec:authorize access="hasAnyRole('ADMIN','USER')">
			<input id="cmt_reply_csrf" type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
		</sec:authorize>
		<input name="cmt_board_no" value="<c:out value='${param.board_no}' default='0'/>" type="hidden">
		<input id="cmt_reply_p_no" name="cmt_p_no" value="0" type="hidden">
		<article class="cmt_write_box">
			<div class="cmt_write_group cmt_nickname">
				<sec:authorize access="isAuthenticated()">
					<span><sec:authentication property="principal.nickname"/></span>
				</sec:authorize>
			</div>
			
			<div class="cmt_write_group">
				<sec:authorize access="isAuthenticated()">
					<textarea id="cmt_reply_content" class="form-control" name="cmt_content" rows="2"></textarea>
				</sec:authorize>
				<sec:authorize access="!isAuthenticated()">
					<textarea id="cmt_content_unauth" class="form-control" rows="2" placeholder="댓글을 달려면 로그인을 해야합니다." readonly></textarea>
				</sec:authorize>
			</div>
			
			<div class="cmt_btn_box">
				<button id="btn_cmt_reply_save" type="button">등록</button>
			</div>
		</article>
	</form>
</section>