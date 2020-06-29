<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="rootPath" value="${pageContext.request.contextPath}"/>
<style>
	article.page_box {
		margin:15px auto;
		padding:16px;
		border-top: 1px solid gree;
		border-buttom: 1px solid gree;
	}
	ul.page_body {
		list-style:none;
		display: flex;
		justify-content: center;
		align-items: center;
	}
	.page_link {
		position: relative;
		display: block;
		padding: 0.5rem 0.75rem;
		line-height: 1.25;
		color:#007bff;
		background-color: #fff;
		border:1px solid #DEE2E6;
		text-decoration: none;
		cursor: pointer;
	}
	.page_link:hover {
		color:#0056B3;
		background-color: #E9ECEF;
		border-color: #DEE2E6;
		text-decoration: none;
	}
	.page_link:focus {
		z-index:3;
		outline: 0;
		box-shadow: 0 0 0 0.2rem rgba(0,123,255,0.25);
	}
	li.page_item.active .page_link{
		z-index:3;
		color:#fff;
		background-color: #007BFF;
		border-color:  #007BFF;
	}
</style>
<script>
	$(function() {
		$(document).off("click", ".page_middot").on("click", ".page_middot", function() {
			let jump_page = prompt("이동할 페이지 \(1~" + ${PAGE_DTO.lastPageNo} + "\)")
			
			if(jump_page == null) {
				let requestURL = "${rootPath}/comment/list"
				let query = "?currPage=" + jump_page + "${PAGE_DEFAULT_QUERY}"
				requestURL += query
				
				$.ajax({
					url: requestURL,
					type: "GET",
					success: function(result) {
						$(".cmt_list").html(result)
					},
					error: function(error) {
						console.log("댓글 불러오기 실패")
					}
				})
			}
		})
		
		$(document).on("click", ".page_link", function() {
			let requestURL = "${rootPath}/comment/list"
			let query = $(this).data("href")
			requestURL += query
			
			$.ajax({
				url: requestURL,
				type: "GET",
				success: function(result) {
					$(".cmt_list").html(result)
				},
				error: function(error) {
					console.log("댓글 불러오기 실패")
				}
			})
		})
	})
</script>
<article class="page_box">
	<ul class="page_body">
		<li class="page_item"><span class="page_link" data-href="?currPage=1${PAGE_DEFAULT_QUERY}">처음</span></li>
		<li class="page_item"><span class="page_link page_middot">&middot;&middot;&middot;</span></li>
		
		<c:forEach begin="${PAGE_DTO.startPageNo}" end="${PAGE_DTO.endPageNo}" var="pageNo">
			<li class="page_item <c:if test='${pageNo == PAGE_DTO.currentPageNo}'>active</c:if>"><span class="page_link" data-href="?currPage=${pageNo}${PAGE_DEFAULT_QUERY}">${pageNo}</span></li>
		</c:forEach>
		
		<li class="page_item"><span class="page_link page_middot">&middot;&middot;&middot;</span></li>
		<li class="page_item"><span class="page_link" data-href="?currPage=${PAGE_DTO.lastPageNo}${PAGE_DEFAULT_QUERY}">끝</span></li>
	</ul>
</article>